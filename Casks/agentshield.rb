cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1674"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1674/agentshield_0.2.1674_darwin_amd64.tar.gz"
      sha256 "908f675e362e06b27eae73e655fc35ba22140af9f689c0f50d3f9296776d80ff"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1674/agentshield_0.2.1674_darwin_arm64.tar.gz"
      sha256 "59ca0dd661621f9120d0c7ffe983d67e81871dd21369c2b9a8b95eb43944b2c2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1674/agentshield_0.2.1674_linux_amd64.tar.gz"
      sha256 "205af0fcb90ac5cf7f39540b819d50b62747e4314ab500bbc652b40e1a22efb7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1674/agentshield_0.2.1674_linux_arm64.tar.gz"
      sha256 "5eb5689fc31302cc6ea088b32f88f56c10f25fe2c9fab4d3842b1af35be92e78"
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
