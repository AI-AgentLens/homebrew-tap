cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.513"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.513/agentshield_0.2.513_darwin_amd64.tar.gz"
      sha256 "e7d795aabea651c3924b3de69abd49638ee779be7321c094ade092f9a956bfa3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.513/agentshield_0.2.513_darwin_arm64.tar.gz"
      sha256 "0f86bd15c3e86edc30b4474b6b180f764da4cfb850cb66b19a2efa1b4f2c87dd"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.513/agentshield_0.2.513_linux_amd64.tar.gz"
      sha256 "0fbb2714e6e9261cd47e27623bed6a54f078ab59a9b8ba1dd4154117cb546331"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.513/agentshield_0.2.513_linux_arm64.tar.gz"
      sha256 "34fc66dfdc48ae8ace50a0d13c22e3e7c2ee9119c75e94caecde982f89fc4aa6"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
