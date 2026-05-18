cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1021"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1021/agentshield_0.2.1021_darwin_amd64.tar.gz"
      sha256 "d05ecf2b2d06f3040c1868db1b8b9865ed111f631f85a13553b176f2f9f25a2e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1021/agentshield_0.2.1021_darwin_arm64.tar.gz"
      sha256 "735d356b0fd7f8d7e2a703d7c1015705196581c779926caf85e1a85fd9402c07"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1021/agentshield_0.2.1021_linux_amd64.tar.gz"
      sha256 "e516ea8d678cc43afb93dfc4ff72d17d725ab2dbc1bfefb7e595a676298928ab"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1021/agentshield_0.2.1021_linux_arm64.tar.gz"
      sha256 "5df0f1972186447439ddab5913e0180a6c226fe488b0b7a35d154035a322d51a"
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
