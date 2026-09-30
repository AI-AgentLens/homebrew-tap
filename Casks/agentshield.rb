cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2299"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2299/agentshield_0.2.2299_darwin_amd64.tar.gz"
      sha256 "015da69ad32170807a4eed6d13f9e8b3db8975aa57a5c4b679a70a849b69a9fb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2299/agentshield_0.2.2299_darwin_arm64.tar.gz"
      sha256 "8ab319d31a05e221dff48682893271559847f2b986674ff4887e03ec0c14935f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2299/agentshield_0.2.2299_linux_amd64.tar.gz"
      sha256 "0925bc173cc4f83a6b58b9aafbb30dcd6bd29cd479be722847a984c66ff126d6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2299/agentshield_0.2.2299_linux_arm64.tar.gz"
      sha256 "9fd91a887328de2ca7512b90ffb5772f58892272047b70d9511efef4f1cb64d3"
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
