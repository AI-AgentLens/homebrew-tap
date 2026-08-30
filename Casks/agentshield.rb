cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1989"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1989/agentshield_0.2.1989_darwin_amd64.tar.gz"
      sha256 "1beb2c7004df5c7f9f9155ec01af9006e8d6fc30d6fad235945290788b3e39ed"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1989/agentshield_0.2.1989_darwin_arm64.tar.gz"
      sha256 "88aea23b770eb3645eda4e5a3f5cb1b97519c149af73076414b264c0fd1fb4f0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1989/agentshield_0.2.1989_linux_amd64.tar.gz"
      sha256 "df6a96c516116b296dfa70f118228373fd42b883f9d4c01ea941beaa38e8c394"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1989/agentshield_0.2.1989_linux_arm64.tar.gz"
      sha256 "9f1c3ccaba13657feb0fe5dd77d259eb9146ee4f4bedd9c642f8c0a3fff93fd4"
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
