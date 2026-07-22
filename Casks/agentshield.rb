cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1706"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1706/agentshield_0.2.1706_darwin_amd64.tar.gz"
      sha256 "2e2e0ff76fc3da29209c7b0bfe18ebf5653805d3d9524615a7e3363ee36d55ee"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1706/agentshield_0.2.1706_darwin_arm64.tar.gz"
      sha256 "7799de16a62cd4ea2d5df259238b4e63c88bcbb74c21245f8776bb4b8789c46f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1706/agentshield_0.2.1706_linux_amd64.tar.gz"
      sha256 "5ef879b87629253c2ddfbf283c4c644271a9bd5691ca856ea553198b47d19d6e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1706/agentshield_0.2.1706_linux_arm64.tar.gz"
      sha256 "7a19dd4fa14ca1d82529968d25ef81b9a273b85b2a79b4709eeba2ae5e41171e"
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
