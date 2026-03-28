cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.143"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.143/agentshield_0.2.143_darwin_amd64.tar.gz"
      sha256 "fa5e521b7dcfa2b671903c4259a9229f6b1ea6d31999e80672d006d984d52b72"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.143/agentshield_0.2.143_darwin_arm64.tar.gz"
      sha256 "b1415be7c5a13530619e7c80a7f92d7d1371cc19dbe64815b9dcdcc227c40ad2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.143/agentshield_0.2.143_linux_amd64.tar.gz"
      sha256 "eff159efc07247b5cbaa9539093d4dbaa5e8845d6945dfe31bd05a8ec8a5b51d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.143/agentshield_0.2.143_linux_arm64.tar.gz"
      sha256 "f22f2ef83da62b7d02a6c8cda7ae189cfbe575d706c8bdd2f3734a3e36598b98"
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
