cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.975"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.975/agentshield_0.2.975_darwin_amd64.tar.gz"
      sha256 "c898e305767ccd42407415c9f68861ec7819654183548d55c20a2777b2a35b02"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.975/agentshield_0.2.975_darwin_arm64.tar.gz"
      sha256 "3685772789f60c3ab59fc277ff1ef5855e73aa21f046447802fe6028c273b428"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.975/agentshield_0.2.975_linux_amd64.tar.gz"
      sha256 "a9882e4cbe05c8c16bfd16c8714aca6081da9bb6ffa94eae4f1004a9383de12a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.975/agentshield_0.2.975_linux_arm64.tar.gz"
      sha256 "2ba90f85b47c6953899d6a4fd11ee17fd613f68b1079824c6afae74f0d6b7e3d"
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
