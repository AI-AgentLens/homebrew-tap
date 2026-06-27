cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1469"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1469/agentshield_0.2.1469_darwin_amd64.tar.gz"
      sha256 "41ef2dcdccf02b2ed1888a6ee210506a196bc07f520c4be0d4be13b79d713c2a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1469/agentshield_0.2.1469_darwin_arm64.tar.gz"
      sha256 "a1e1434ca3780415ef4d0c1cd723aef326ec4924251c9bb1963b1ca596788633"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1469/agentshield_0.2.1469_linux_amd64.tar.gz"
      sha256 "a7458bc49e82ac219585c202b80815c1be7f65bcb89de6ab3d548ea9fd0e8697"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1469/agentshield_0.2.1469_linux_arm64.tar.gz"
      sha256 "693252fc79b7866b1904eec018f59cc68258359521d340ac381ead897f9710da"
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
