cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1941"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1941/agentshield_0.2.1941_darwin_amd64.tar.gz"
      sha256 "9865ae0331c5e2598102c92c7940d50ecbb4b04c3bbe78556be601351cbd5175"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1941/agentshield_0.2.1941_darwin_arm64.tar.gz"
      sha256 "b048b8d46529711630304ad17550b34c36fe142ff55a18338f21e4f90db098e3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1941/agentshield_0.2.1941_linux_amd64.tar.gz"
      sha256 "b536f40061a6a56dcee2f6c87f12b660a277e28cd7e4ba91e22303e7641a9dbc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1941/agentshield_0.2.1941_linux_arm64.tar.gz"
      sha256 "75b2fabdc0df758b0aab5025b1d59bb0d0dc02f415765869337e346475eebafd"
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
