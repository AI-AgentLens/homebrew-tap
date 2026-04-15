cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.595"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.595/agentshield_0.2.595_darwin_amd64.tar.gz"
      sha256 "970c9dd68fbb4d61eadce705c45a8d8844796ad2caf4150b5bad41e3bb8e4940"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.595/agentshield_0.2.595_darwin_arm64.tar.gz"
      sha256 "dafbc0562cd9c56b524f37fc07053cc426ab2018d19dcffab8eaed5c79cfdde6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.595/agentshield_0.2.595_linux_amd64.tar.gz"
      sha256 "34fe375ce65790d6ccef576755e1a63fd8db79019c5bf1fba0fd7a912cce0f1b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.595/agentshield_0.2.595_linux_arm64.tar.gz"
      sha256 "000bfdccb735fb16500664ad3dd45f82de8192ff800cebad4a965e2e856c37cf"
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
