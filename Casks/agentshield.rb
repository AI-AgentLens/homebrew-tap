cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1317"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1317/agentshield_0.2.1317_darwin_amd64.tar.gz"
      sha256 "958fb4752bbae834dc20b725dc89188ef493c05628189e074452454e470a61c1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1317/agentshield_0.2.1317_darwin_arm64.tar.gz"
      sha256 "6366455b4c633062d5274bce629786b1deb2d9fe10bf62a258d6a4c8832a47ff"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1317/agentshield_0.2.1317_linux_amd64.tar.gz"
      sha256 "1e061250da5147022de2ab4d5ebd015a7f61debcb8f01a5ca380bcbf14aa624f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1317/agentshield_0.2.1317_linux_arm64.tar.gz"
      sha256 "cb8668bfac6a8dfa874d447e5c6c45331a7ee3acebac525d7626b0c57f59e00c"
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
