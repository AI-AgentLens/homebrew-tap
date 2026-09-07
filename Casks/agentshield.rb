cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2070"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2070/agentshield_0.2.2070_darwin_amd64.tar.gz"
      sha256 "9ac35c11b33f2e6ea182a0eba3c79031bef712419a9f60125a5fcbe467af98d7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2070/agentshield_0.2.2070_darwin_arm64.tar.gz"
      sha256 "3f6c88cbc18808c38a41f24b9e795fb34dddcc3bb3dad5e3ff03012c7b931c53"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2070/agentshield_0.2.2070_linux_amd64.tar.gz"
      sha256 "76a783fd25b837a3e2fca4b9f7bf848a6b3fad0eb15e44d3e36a084990427d9b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2070/agentshield_0.2.2070_linux_arm64.tar.gz"
      sha256 "aa220d7ed969c5946274be776bb279a217546ad9b6d8a72531035c500c42020e"
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
