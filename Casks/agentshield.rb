cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.568"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.568/agentshield_0.2.568_darwin_amd64.tar.gz"
      sha256 "8cd4834e8ea45b93c611567f20be479494f9de0e26e034e5d44670fbf1af649c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.568/agentshield_0.2.568_darwin_arm64.tar.gz"
      sha256 "bb22e8190028ea5202457dd450063f80ca65433ad0c6a15cdbed192e2f0b5ca3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.568/agentshield_0.2.568_linux_amd64.tar.gz"
      sha256 "29c1817ca51d9126d6b15ee6428d6114980c474a698d56acab3bb8a6a9e54977"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.568/agentshield_0.2.568_linux_arm64.tar.gz"
      sha256 "45740803c8c8be3db1af1d16d33f461f4ebbdea48f3b4a053289bbf0968ca318"
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
