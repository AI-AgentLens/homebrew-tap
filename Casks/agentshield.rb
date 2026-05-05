cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.885"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.885/agentshield_0.2.885_darwin_amd64.tar.gz"
      sha256 "effbafb4ea0ae2467cebecdf7d3e64e6cf6f132583e2d03e9c5191bba3fa5501"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.885/agentshield_0.2.885_darwin_arm64.tar.gz"
      sha256 "636fcfb68270541f72b64a857ae75714f6a56d472d01a24bcb301d72a3fcb142"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.885/agentshield_0.2.885_linux_amd64.tar.gz"
      sha256 "442a71dfe2183d7bc3f62910699e70cd5414e8a79a68f52dd869621ae97310d3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.885/agentshield_0.2.885_linux_arm64.tar.gz"
      sha256 "350e96c7dab4eff548718a2b74c59c9898550f1a5448fe529e101d42a733826d"
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
