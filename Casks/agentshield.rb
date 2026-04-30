cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.832"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.832/agentshield_0.2.832_darwin_amd64.tar.gz"
      sha256 "2c8db26a8ad61a7b93eebb0fe81f10342c09f4be66edd627e12a5030d9208531"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.832/agentshield_0.2.832_darwin_arm64.tar.gz"
      sha256 "50156ec4cdac3778752f2885994ff971072abe8a5a1ea920e93df115b285682e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.832/agentshield_0.2.832_linux_amd64.tar.gz"
      sha256 "450578748faf97565fd513d15387e33ba35098895d2223382bf752a900d0bf04"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.832/agentshield_0.2.832_linux_arm64.tar.gz"
      sha256 "bd7a44a9aaa00b70c308cf35fed759b5441b141d09c21d2c9d6f2d44c17b6715"
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
