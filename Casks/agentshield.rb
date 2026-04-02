cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.344"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.344/agentshield_0.2.344_darwin_amd64.tar.gz"
      sha256 "7e06312fdc4210869f3b454b84a094316ac9913d7ebae3d987af11ce113042a3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.344/agentshield_0.2.344_darwin_arm64.tar.gz"
      sha256 "afdb3130df693ea46f677696c9b9797e4ac510422e6cf1517e8865f6c1f0335c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.344/agentshield_0.2.344_linux_amd64.tar.gz"
      sha256 "6bd6fededda492457bdd2705e6065ad42dafee816250749eb9e2fe8b3445956c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.344/agentshield_0.2.344_linux_arm64.tar.gz"
      sha256 "7f0dd31b414763f1f705d6d88aaefbb28fb64bc910a059b62ee5bc7ac57723df"
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
